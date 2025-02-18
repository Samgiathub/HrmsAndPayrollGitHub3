using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsResumeImmigration
{
    public string? LocName { get; set; }

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

    public string? ResumeCode { get; set; }

    public string AttachDocuments { get; set; } = null!;
}
