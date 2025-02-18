using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040ReasonMaster
{
    public int ResId { get; set; }

    public string ReasonName { get; set; } = null!;

    public byte Isactive { get; set; }

    public string? Type { get; set; }

    public string GatePassType { get; set; } = null!;

    public byte IsMandatory { get; set; }

    public string StatusColor { get; set; } = null!;
}
