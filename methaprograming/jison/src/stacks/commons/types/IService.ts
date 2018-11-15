import { Observable } from 'rxjs';

export abstract class IService<T> {

  abstract findAll(): Observable<T[]>;
}
