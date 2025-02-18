using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0065EmpReferenceDetailApp
{
    public long EmpTranId { get; set; }

    public int EmpApplicationId { get; set; }

    public int ReferenceId { get; set; }

    public int CmpId { get; set; }

    public int REmpId { get; set; }

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

    public int? ApprovedEmpId { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? RptLevel { get; set; }

    public virtual T0060EmpMasterApp EmpTran { get; set; } = null!;
}
