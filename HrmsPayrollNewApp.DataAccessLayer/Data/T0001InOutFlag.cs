using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0001InOutFlag
{
    public int IoflagId { get; set; }

    public int? IoTranId { get; set; }

    public int? Flag { get; set; }

    public DateTime? CreatedDate { get; set; }
}
