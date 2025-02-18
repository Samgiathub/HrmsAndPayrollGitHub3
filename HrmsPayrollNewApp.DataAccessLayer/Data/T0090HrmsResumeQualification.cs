using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsResumeQualification
{
    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ResumeId { get; set; }

    public decimal QualId { get; set; }

    public string? Specialization { get; set; }

    public decimal? Year { get; set; }

    public decimal? Score { get; set; }

    public DateTime? StDate { get; set; }

    public DateTime? EndDate { get; set; }

    public string? Comments { get; set; }

    public string? EduCertificatePath { get; set; }

    public string? University { get; set; }

    public string? Division { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040QualificationMaster Qual { get; set; } = null!;

    public virtual T0055ResumeMaster Resume { get; set; } = null!;
}
