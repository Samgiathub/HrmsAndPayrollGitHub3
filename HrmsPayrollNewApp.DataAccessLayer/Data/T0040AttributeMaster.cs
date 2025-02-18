using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040AttributeMaster
{
    public decimal AttributeId { get; set; }

    public decimal CmpId { get; set; }

    public string? AttributeName { get; set; }

    public string? Description { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
