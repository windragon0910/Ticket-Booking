import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { IsEmail, IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { Schema } from 'mongoose';

export type RawUserPayload = {
  uid: string,
  email?: string,
  _id?: Schema.Types.ObjectId | null | undefined;
};

export class UserPayload {
  @IsString()
  @IsNotEmpty()
  readonly uid: string;

  @IsString()
  @IsEmail()
  readonly email: string;

  @IsOptional()
  readonly _id?: Schema.Types.ObjectId | null | undefined;

  constructor(payload: RawUserPayload) {
    this.uid = payload.uid;
    this.email = payload.email;
    this._id = payload._id;
  }
}

export const GetUser = createParamDecorator(
    (data: unknown, ctx: ExecutionContext) => {
      const req: { user?: UserPayload | null } = ctx.switchToHttp().getRequest();
      return data && typeof data === 'string' ? req.user?.[data] : req.user;
    }
);

