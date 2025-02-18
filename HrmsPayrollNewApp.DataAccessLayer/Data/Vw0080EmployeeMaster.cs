using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class Vw0080EmployeeMaster
{
    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpCode { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string EmpSecondName { get; set; } = null!;

    public string EmpLastName { get; set; } = null!;

    public DateTime DateOfJoin { get; set; }

    public decimal? BasicSalary { get; set; }

    public string ShiftName { get; set; } = null!;

    public string DeptName { get; set; } = null!;

    public string DesigName { get; set; } = null!;

    public string? Gender { get; set; }

    public string? TypeName { get; set; }
}
