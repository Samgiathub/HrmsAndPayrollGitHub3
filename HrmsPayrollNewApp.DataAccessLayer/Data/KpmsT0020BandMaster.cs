using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsT0020BandMaster
{
    public int CmpId { get; set; }

    public int BandId { get; set; }

    public string BandCode { get; set; } = null!;

    public string BandName { get; set; } = null!;

    public int IsActive { get; set; }

    public int UserId { get; set; }

    public DateTime CreatedDate { get; set; }

    public DateTime? ModifyDate { get; set; }
}
