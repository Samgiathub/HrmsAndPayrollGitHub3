using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V1000EmployeeJoiningReport
{
    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public string? EmpLeft { get; set; }

    public DateTime DateOfJoin { get; set; }

    public string? Gender { get; set; }

    public string DeptName { get; set; } = null!;

    public string DesigName { get; set; } = null!;

    public string ShiftName { get; set; } = null!;

    public string? SkillName { get; set; }

    public string GrdName { get; set; } = null!;

    public decimal EmpCode { get; set; }

    public string? TypeName { get; set; }

    public string? Street1 { get; set; }

    public string? City { get; set; }

    public string? State { get; set; }

    public string? ZipCode { get; set; }

    public string? PresentStreet { get; set; }

    public string? PresentCity { get; set; }

    public string? PresentState { get; set; }

    public string? PresentPostBox { get; set; }
}
