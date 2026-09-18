import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import type { Request, Response } from 'express';
import { ErrorCode } from './error-codes';

interface ErrorEnvelope {
  code: string;
  message: string;
  details?: unknown;
  requestId?: string;
}

const STATUS_TO_CODE: Record<number, string> = {
  400: ErrorCode.VALIDATION_FAILED,
  401: ErrorCode.UNAUTHORIZED,
  403: ErrorCode.FORBIDDEN,
  404: ErrorCode.NOT_FOUND,
  409: ErrorCode.INVALID_STATE_TRANSITION,
  429: ErrorCode.RATE_LIMITED,
};

/**
 * ONW-17: любое исключение превращается в один конверт {code, message, details}.
 * Внутренние детали наружу не уходят, но пишутся в лог с request-id.
 */
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger(AllExceptionsFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const res = ctx.getResponse<Response>();
    const req = ctx.getRequest<Request>();
    const requestId = req.header('x-request-id') ?? undefined;

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let body: ErrorEnvelope = { code: ErrorCode.INTERNAL, message: 'Внутренняя ошибка сервера' };

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const response = exception.getResponse();
      if (typeof response === 'object' && response !== null && 'code' in response) {
        body = response as ErrorEnvelope;
      } else {
        const message =
          typeof response === 'string'
            ? response
            : ((response as { message?: string | string[] }).message ?? exception.message);
        body = {
          code: STATUS_TO_CODE[status] ?? ErrorCode.INTERNAL,
          message: Array.isArray(message) ? 'Ошибка валидации' : message,
          details: Array.isArray(message) ? message : undefined,
        };
      }
    } else {
      this.logger.error(
        { err: exception, requestId, path: req.url },
        'Необработанное исключение',
      );
    }

    res.status(status).json({ ...body, requestId });
  }
}
