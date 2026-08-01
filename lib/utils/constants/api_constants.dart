/// Every path here mirrors internal/routes/routes.go on the backend
/// exactly (path shape, not method — see each service for which
/// HTTP verb hits which path). Kept as static getters/functions
/// instead of scattering literal strings across every service file,
/// so a backend route rename only needs updating in one place.
class AdipsApiConstants {
  AdipsApiConstants._();

  // ---- /api/v1/transactions ----------------------------------------
  static const String transactions = '/api/v1/transactions';
  static String transaction(int id) => '$transactions/$id';
  static const String transactionsSummary = '$transactions/summary';

  // ---- /api/v1/settings ---------------------------------------------
  static const String settings = '/api/v1/settings';

  // ---- /api/v1/transaction-types -------------------------------------
  static const String transactionTypes = '/api/v1/transaction-types';
  static String transactionType(int id) => '$transactionTypes/$id';

  // ---- /api/v1/categories --------------------------------------------
  static const String categories = '/api/v1/categories';
  static String category(int id) => '$categories/$id';
  static const String categoriesReorder = '$categories/reorder';

  // ---- /api/v1/users --------------------------------------------------
  static const String signup = '/api/v1/users/signup';
  static const String login = '/api/v1/users/login';
  static const String logout = '/api/v1/users/logout';
  static const String validate = '/api/v1/users/validate';
}