using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsResumeExp
{
    public string? DesigName { get; set; }

    public DateTime? StDate { get; set; }

    public string? EndDate { get; set; }

    public decimal ResumeId { get; set; }

    public decimal CmpId { get; set; }

    public string? EmployerName { get; set; }

    public decimal RowId { get; set; }

    public string? ResumeCode { get; set; }

    public string? ExpProof { get; set; }

    public string? DocumentType { get; set; }

    public DateTime? Fromdate { get; set; }

    public DateTime? Todate { get; set; }

    public decimal? GrossSalary { get; set; }

    public decimal? ProfessionalTax { get; set; }

    public decimal? Surcharge { get; set; }

    public decimal? EducationCess { get; set; }

    public decimal? Tds { get; set; }

    public string? AppFullName { get; set; }

    public decimal? Itax { get; set; }

    public string? Fyear { get; set; }

    public byte StillContinue { get; set; }

    public byte Fresher { get; set; }

    public decimal Ctc { get; set; }

    public string ManagerName { get; set; } = null!;

    public string ManagerContactNo { get; set; } = null!;

    public string ReasonForLeaving { get; set; } = null!;
}
