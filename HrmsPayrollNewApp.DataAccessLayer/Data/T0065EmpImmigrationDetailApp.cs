using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0065EmpImmigrationDetailApp
{
    public long EmpTranId { get; set; }

    public int EmpApplicationId { get; set; }

    public int RowId { get; set; }

    public int CmpId { get; set; }

    public int? LocId { get; set; }

    public string ImmType { get; set; } = null!;

    public string ImmNo { get; set; } = null!;

    public DateTime? ImmIssueDate { get; set; }

    public string ImmIssueStatus { get; set; } = null!;

    public DateTime? ImmDateOfExpiry { get; set; }

    public DateTime? ImmReviewDate { get; set; }

    public string ImmComments { get; set; } = null!;

    public string? AttachDoc { get; set; }

    public int? ApprovedEmpId { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? RptLevel { get; set; }

    public virtual T0060EmpMasterApp EmpTran { get; set; } = null!;
}
