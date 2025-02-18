using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090EmpImmigrationDetailGet
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

    public string? LocName { get; set; }
}
