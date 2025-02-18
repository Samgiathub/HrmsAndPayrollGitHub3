using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100GratuityCalculation
{
    public decimal EmpId { get; set; }

    public decimal BranchId { get; set; }

    public string? EmpFullName { get; set; }

    public DateTime PaidDate { get; set; }

    public decimal GrCalcAmount { get; set; }

    public decimal GrPercentage { get; set; }

    public decimal GrDays { get; set; }

    public string? BranchName { get; set; }

    public decimal Branch { get; set; }

    public decimal GrAmount { get; set; }

    public decimal CmpId { get; set; }

    public decimal GrdId { get; set; }

    public string? DesigName { get; set; }

    public string? DeptName { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal EmpCode1 { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string EmpLastName { get; set; } = null!;

    public string? MaritalStatus { get; set; }

    public string? Gender { get; set; }

    public decimal GrId { get; set; }

    public string? EmpCode { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal GrYears { get; set; }
}
