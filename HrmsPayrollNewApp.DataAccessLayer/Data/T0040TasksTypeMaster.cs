using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040TasksTypeMaster
{
    public int TaskTypeId { get; set; }

    public string? TtmCode { get; set; }

    public string? TtmTitle { get; set; }

    public int? TtmStatus { get; set; }

    public DateTime? TtmCreatedDate { get; set; }

    public DateTime? TtmUpdatedDate { get; set; }
}
