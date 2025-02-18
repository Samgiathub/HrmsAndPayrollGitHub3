using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080EmpProbationGet
{
    public DateTime? ProbationDate { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public DateTime DateOfJoin { get; set; }

    public decimal? Probation { get; set; }

    public string? BranchName { get; set; }

    public string? DeptName { get; set; }

    public string? DesigName { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal BranchId { get; set; }

    public decimal? CatId { get; set; }

    public decimal GrdId { get; set; }

    public decimal DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? TypeId { get; set; }

    public string? EmpLeft { get; set; }

    public byte? IsOnProbation { get; set; }

    public DateTime? NewProbationEndDate { get; set; }

    public decimal? NewProbPeriod { get; set; }

    public string? WorkEmail { get; set; }

    public string Flag { get; set; } = null!;

    public string EmpFirstName { get; set; } = null!;

    public string? GrdName { get; set; }

    public string? TypeName { get; set; }

    public decimal? EmpTypeId { get; set; }

    public string ProbationReview { get; set; } = null!;

    public string TrainingId { get; set; } = null!;

    public string? ApprovalPeriodType { get; set; }

    public byte IsProbationMonthDays { get; set; }

    public string AttachDocs { get; set; } = null!;

    public DateTime? ConfirmationDate { get; set; }
}
