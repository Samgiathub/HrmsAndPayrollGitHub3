using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0250DigitalSignaturePositionSetting
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public string Module { get; set; } = null!;

    public decimal Param1 { get; set; }

    public decimal Param2 { get; set; }

    public decimal Param3 { get; set; }

    public decimal Param4 { get; set; }

    public decimal PageNo { get; set; }
}
