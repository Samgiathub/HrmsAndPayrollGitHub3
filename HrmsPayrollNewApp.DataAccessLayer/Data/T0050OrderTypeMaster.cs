using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050OrderTypeMaster
{
    public decimal OrderTypeId { get; set; }

    public decimal CmpId { get; set; }

    public string OrderTypeName { get; set; } = null!;

    public string? Remarks { get; set; }

    public DateTime? ModifyDate { get; set; }
}
