using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050BillTypeMaster
{
    public int BillId { get; set; }

    public int? CmpId { get; set; }

    public string? BillName { get; set; }

    public string? BillFieldtypeId { get; set; }

    public DateTime? SystemDate { get; set; }
}
