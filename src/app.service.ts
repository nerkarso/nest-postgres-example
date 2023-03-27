import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return 'Hello World!';
  }

  getPerson(name: string): string {
    return `Hello ${name}!`;
  }
}
