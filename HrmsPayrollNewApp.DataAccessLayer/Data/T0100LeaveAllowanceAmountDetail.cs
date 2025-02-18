using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100LeaveAllowanceAmountDetail
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal LeaveId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public decimal Amount { get; set; }

    public DateTime SysDate { get; set; }
}
