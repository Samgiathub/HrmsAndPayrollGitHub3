using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040ReasonMaster
{
    public int ResId { get; set; }

    public string? ReasonName { get; set; }

    public byte? Isactive { get; set; }

    public string? Type { get; set; }

    public string? GatePassType { get; set; }

    public byte IsMandatory { get; set; }

    public bool? IsDefault { get; set; }

    public virtual ICollection<T0060ExtraIncrementUtility> T0060ExtraIncrementUtilities { get; set; } = new List<T0060ExtraIncrementUtility>();
}
