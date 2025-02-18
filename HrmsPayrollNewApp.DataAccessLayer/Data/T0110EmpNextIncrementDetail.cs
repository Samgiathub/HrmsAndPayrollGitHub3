using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110EmpNextIncrementDetail
{
    public int TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime NextIncrementDate { get; set; }

    public DateTime SystemDate { get; set; }

    public decimal UserId { get; set; }

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
