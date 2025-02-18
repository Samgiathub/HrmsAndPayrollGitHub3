using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100WarningDetailsBkronak171023
{
    public decimal WarTranId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime WarrDate { get; set; }

    public string WarrReason { get; set; } = null!;

    public string IssueBy { get; set; } = null!;

    public string AuthorisedBy { get; set; } = null!;

    public string? WarName { get; set; }

    public decimal? DeductRate { get; set; }

    public decimal? EmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? ShiftName { get; set; }

    public decimal ShiftId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? GrdId { get; set; }

    public string? BranchName { get; set; }

    public string? DeptName { get; set; }

    public string? GrdName { get; set; }

    public string? EmpFirstName { get; set; }

    public decimal WarId { get; set; }

    public decimal? CmpId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal? EmpSuperior { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal LevelId { get; set; }

    public string? LevelName { get; set; }

    public decimal? NoOfCard { get; set; }

    public string? CardColor { get; set; }

    public DateTime? ActionTakenDate { get; set; }

    public string? ActionDetail { get; set; }
}
