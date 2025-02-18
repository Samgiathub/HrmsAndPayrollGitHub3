using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0030DocumentTypeMaster
{
    public decimal DocTypeId { get; set; }

    public string DocTypeName { get; set; } = null!;

    public string DocComments { get; set; } = null!;
}
