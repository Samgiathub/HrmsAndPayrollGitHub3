using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0301PaymentProcessType
{
    public decimal TranId { get; set; }

    public string PaymentProcessName { get; set; } = null!;

    public string? PaymentAllowance { get; set; }

    public byte IsActive { get; set; }
}
