using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090DevelopmentPlanningTemplate
{
    public decimal EmpDptId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public int? DptStatus { get; set; }

    public int? FinYear { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmployeeName { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public string? DesigName { get; set; }

    public string? DeptName { get; set; }

    public string? EmpComment { get; set; }

    public string? ManagerComment { get; set; }

    public DateTime StartDate { get; set; }

    public DateTime Enddate { get; set; }
}
