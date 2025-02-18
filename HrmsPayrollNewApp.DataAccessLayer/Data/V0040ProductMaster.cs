using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040ProductMaster
{
    public decimal ProductId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LoginId { get; set; }

    public string ProductName { get; set; } = null!;

    public DateTime? SystemDate { get; set; }
}
