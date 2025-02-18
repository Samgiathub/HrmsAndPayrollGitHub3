using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpImmigrationDetail
{
    public decimal EmpId { get; set; }

    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? LocId { get; set; }

    public string ImmType { get; set; } = null!;

    public string ImmNo { get; set; } = null!;

    public DateTime? ImmIssueDate { get; set; }

    public string ImmIssueStatus { get; set; } = null!;

    public DateTime? ImmDateOfExpiry { get; set; }

    public DateTime? ImmReviewDate { get; set; }

    public string ImmComments { get; set; } = null!;

    public string? AttachDoc { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0001LocationMaster? Loc { get; set; }
}
