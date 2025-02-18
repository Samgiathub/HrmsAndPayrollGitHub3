using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0070EmpSchemeApp
{
    public long EmpTranId { get; set; }

    public int EmpApplicationId { get; set; }

    public int TranId { get; set; }

    public int CmpId { get; set; }

    public int SchemeId { get; set; }

    public string Type { get; set; } = null!;

    public int? ApprovedEmpId { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? RptLevel { get; set; }

    public virtual T0060EmpMasterApp EmpTran { get; set; } = null!;
}
