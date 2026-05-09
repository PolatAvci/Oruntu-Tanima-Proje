import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Abstract class for all use cases in the application.
/// [ResultType] is the return type of the use case.
/// [Params] is the input parameter type.
///
/// Every use case implements this to ensure consistent error handling
/// via the Either monad (Right for success, Left for failure).
abstract class UseCase<ResultType, Params> {
  Future<Either<Failure, ResultType>> call(Params params);
}

/// Use case that does not require any parameters.
class NoParams {
  const NoParams();
}
