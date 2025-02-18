using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090EmpReferenceDetail
{
    public decimal ReferenceId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal REmpId { get; set; }

    public DateTime ForDate { get; set; }

    public string? RefDescription { get; set; }

    public string? Amount { get; set; }

    public string? Comments { get; set; }

    public int SourceType { get; set; }

    public string? ContactPerson { get; set; }

    public string? Designation { get; set; }

    public string? City { get; set; }

    public string? Mobile { get; set; }

    public string? Description { get; set; }

    public string SourceTypeName { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? SourceName { get; set; }

    public decimal? Month { get; set; }

    public decimal? Year { get; set; }

    public string? Monthyear { get; set; }

    public string EffectInSalary { get; set; } = null!;
}
