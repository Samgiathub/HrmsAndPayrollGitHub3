using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpContractDetailClone
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal PrjId { get; set; }

    public DateTime StartDate { get; set; }

    public DateTime EndDate { get; set; }

    public byte IsRenew { get; set; }

    public byte IsReminder { get; set; }

    public string? Comments { get; set; }

    public DateTime SystemDate { get; set; }

    public decimal LoginId { get; set; }
}
