using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsResumeNominee
{
    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ResumeId { get; set; }

    public string? MemberName { get; set; }

    public decimal? MemberAge { get; set; }

    public string? Relationship { get; set; }

    public string? Occupation { get; set; }

    public string? Comments { get; set; }

    public DateTime? MemberDateOfBirth { get; set; }

    public decimal? RelationshipId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0055ResumeMaster Resume { get; set; } = null!;
}
