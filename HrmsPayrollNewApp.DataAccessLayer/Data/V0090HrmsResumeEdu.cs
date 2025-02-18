using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsResumeEdu
{
    public decimal? ResumeId { get; set; }

    public decimal? Year { get; set; }

    public decimal? Score { get; set; }

    public decimal QualId { get; set; }

    public string? QualName { get; set; }

    public decimal CmpId { get; set; }

    public string? Specialization { get; set; }

    public DateTime? EndDate { get; set; }

    public DateTime? StDate { get; set; }

    public decimal RowId { get; set; }

    public string? ResumeCode { get; set; }

    public string? Comments { get; set; }

    public string? EduCertificatePath { get; set; }

    public string? University { get; set; }

    public string? Division { get; set; }

    public string? AppFullName { get; set; }
}
