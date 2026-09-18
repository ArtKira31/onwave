import { ArgumentsHost, HttpStatus, NotFoundException } from '@nestjs/common';
import { AllExceptionsFilter } from './all-exceptions.filter';
import { AppException } from './app.exception';
import { ErrorCode } from './error-codes';

function makeHost(): { host: ArgumentsHost; json: jest.Mock; status: jest.Mock } {
  const json = jest.fn();
  const status = jest.fn().mockReturnValue({ json });
  const host = {
    switchToHttp: () => ({
      getResponse: () => ({ status }),
      getRequest: () => ({ url: '/events/1', header: () => 'req-1' }),
    }),
  } as unknown as ArgumentsHost;
  return { host, json, status };
}

describe('AllExceptionsFilter', () => {
  it('отдаёт единый конверт для доменного исключения', () => {
    const { host, json, status } = makeHost();
    new AllExceptionsFilter().catch(
      new AppException(ErrorCode.EVENT_NOT_FOUND, 'Событие не найдено', HttpStatus.NOT_FOUND),
      host,
    );

    expect(status).toHaveBeenCalledWith(HttpStatus.NOT_FOUND);
    expect(json).toHaveBeenCalledWith(
      expect.objectContaining({ code: ErrorCode.EVENT_NOT_FOUND, requestId: 'req-1' }),
    );
  });

  it('маппит стандартное HTTP-исключение в код', () => {
    const { host, json } = makeHost();
    new AllExceptionsFilter().catch(new NotFoundException(), host);
    expect(json).toHaveBeenCalledWith(expect.objectContaining({ code: ErrorCode.NOT_FOUND }));
  });

  it('не раскрывает детали необработанного исключения', () => {
    const { host, json, status } = makeHost();
    new AllExceptionsFilter().catch(new Error('SELECT * FROM users failed'), host);

    expect(status).toHaveBeenCalledWith(HttpStatus.INTERNAL_SERVER_ERROR);
    expect(json).toHaveBeenCalledWith(
      expect.objectContaining({ code: ErrorCode.INTERNAL, message: 'Внутренняя ошибка сервера' }),
    );
  });
});
