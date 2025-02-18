using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0065EmpContractDetailApp
{
    public int TranId { get; set; }

    public int CmpId { get; set; }

    public long EmpTranId { get; set; }

    public int EmpApplicationId { get; set; }

    public int? ApprovedEmpId { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? RptLevel { get; set; }

    public int PrjId { get; set; }

    public DateTime StartDate { get; set; }

    public DateTime EndDate { get; set; }

    public byte IsRenew { get; set; }

    public byte IsReminder { get; set; }

    public string? Comments { get; set; }

    public string PrjName { get; set; } = null!;
}
