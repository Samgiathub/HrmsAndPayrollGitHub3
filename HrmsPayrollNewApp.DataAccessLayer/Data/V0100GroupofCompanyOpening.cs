using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100GroupofCompanyOpening
{
    public decimal CmpId { get; set; }

    public string CmpName { get; set; } = null!;

    public string? CmpAddress { get; set; }

    public string? ImageName { get; set; }

    public byte? IsMain { get; set; }

    public int NoOfPosition { get; set; }
}
