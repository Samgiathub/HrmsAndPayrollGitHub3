using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040ChangeRequestMaster
{
    public decimal TranId { get; set; }

    public decimal? RequestId { get; set; }

    public string? RequestType { get; set; }

    public decimal? CmpId { get; set; }

    public bool? Flag { get; set; }

    public decimal MaxLimit { get; set; }
}
