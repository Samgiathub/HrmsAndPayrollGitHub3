using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsResumeExperience
{
    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ResumeId { get; set; }

    public string? EmployerName { get; set; }

    public string? DesigName { get; set; }

    public DateTime? StDate { get; set; }

    public DateTime? EndDate { get; set; }

    public string? ExpProof { get; set; }

    public string? DocumentType { get; set; }

    public DateTime? Fromdate { get; set; }

    public DateTime? Todate { get; set; }

    public decimal? GrossSalary { get; set; }

    public decimal? ProfessionalTax { get; set; }

    public decimal? Surcharge { get; set; }

    public decimal? EducationCess { get; set; }

    public decimal? Tds { get; set; }

    public decimal? Itax { get; set; }

    public string? Fyear { get; set; }

    public byte? StillContinue { get; set; }

    public byte? Fresher { get; set; }

    public decimal? Ctc { get; set; }

    public string? ManagerName { get; set; }

    public string? ManagerContactNo { get; set; }

    public string? ReasonForLeaving { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0055ResumeMaster Resume { get; set; } = null!;
}
