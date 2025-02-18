using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsResumeImmigration
{
    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ResumeId { get; set; }

    public decimal? LocId { get; set; }

    public string? ImmType { get; set; }

    public string? ImmNo { get; set; }

    public DateTime? ImmIssueDate { get; set; }

    public string? ImmIssueStatus { get; set; }

    public DateTime? ImmDateOfExpiry { get; set; }

    public DateTime? ImmReviewDate { get; set; }

    public string? ImmComments { get; set; }

    public string? AttachDocuments { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0001LocationMaster? Loc { get; set; }

    public virtual T0055ResumeMaster Resume { get; set; } = null!;
}
