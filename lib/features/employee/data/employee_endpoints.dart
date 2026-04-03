class EmployeeEndpoints {
  static const getAllEmployee = "/tenant/attendance-app/employees";
  static String registerEmployeeFace(String employeeCode) {
    return "/tenant/attendance-app/face/register/${employeeCode}";
  }
}
