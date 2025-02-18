using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0230TdsChallanDetail
{
    public decimal TranId { get; set; }

    public decimal ChallanId { get; set; }

    public decimal EmpId { get; set; }

    public decimal TdsAmount { get; set; }

    public decimal EdCess { get; set; }

    public decimal AdditionalAmount { get; set; }

    public virtual T0220TdsChallan Challan { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
