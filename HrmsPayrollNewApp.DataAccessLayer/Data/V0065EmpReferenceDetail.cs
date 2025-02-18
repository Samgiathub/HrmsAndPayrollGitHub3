using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0065EmpReferenceDetail
{
    public int ReferenceId { get; set; }

    public int CmpId { get; set; }

    public long EmpTranId { get; set; }

    public int EmpApplicationId { get; set; }

    public int? ApprovedEmpId { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? RptLevel { get; set; }

    public int REmpId { get; set; }

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
}
