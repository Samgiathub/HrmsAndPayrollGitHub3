using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100LeaveUpload
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal LeaveId { get; set; }

    public decimal Month { get; set; }

    public decimal Year { get; set; }

    public decimal Opening { get; set; }

    public decimal Credit { get; set; }

    public decimal Debit { get; set; }

    public decimal LateAdjustLeave { get; set; }

    public decimal Balance { get; set; }

    public decimal UserId { get; set; }

    public string IpAddress { get; set; } = null!;

    public DateTime ModifyDate { get; set; }
}
