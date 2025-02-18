using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100WarningDetail
{
    public decimal WarTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal WarId { get; set; }

    public DateTime WarrDate { get; set; }

    public decimal ShiftId { get; set; }

    public string WarrReason { get; set; } = null!;

    public string IssueBy { get; set; } = null!;

    public string AuthorisedBy { get; set; } = null!;

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public decimal LevelId { get; set; }

    public decimal NoOfCard { get; set; }

    public string? CardColor { get; set; }

    public DateTime? ActionTakenDate { get; set; }

    public string? ActionDetail { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040WarningMaster War { get; set; } = null!;
}
