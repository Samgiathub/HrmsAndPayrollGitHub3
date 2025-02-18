using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpReferenceDetail
{
    public decimal ReferenceId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal REmpId { get; set; }

    public DateTime ForDate { get; set; }

    public string? RefDescription { get; set; }

    public decimal Amount { get; set; }

    public string? Comments { get; set; }

    public int SourceType { get; set; }

    public int? SourceName { get; set; }

    public string? ContactPerson { get; set; }

    public string? Designation { get; set; }

    public string? City { get; set; }

    public string? Mobile { get; set; }

    public string? Description { get; set; }

    public decimal? RefMonth { get; set; }

    public decimal? RefYear { get; set; }

    public byte EffectInSalary { get; set; }
}
