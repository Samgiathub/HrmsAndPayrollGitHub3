using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0065EmpQualificationDetailApp
{
    public long EmpTranId { get; set; }

    public int EmpApplicationId { get; set; }

    public int RowId { get; set; }

    public int CmpId { get; set; }

    public int QualId { get; set; }

    public string? Specialization { get; set; }

    public decimal? Year { get; set; }

    public string? Score { get; set; }

    public DateTime? StDate { get; set; }

    public DateTime? EndDate { get; set; }

    public string? Comments { get; set; }

    public string? AttachDoc { get; set; }

    public int? ApprovedEmpId { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? RptLevel { get; set; }

    public virtual T0060EmpMasterApp EmpTran { get; set; } = null!;
}
