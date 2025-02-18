using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class PosMaster
{
    public int PosId { get; set; }

    public string PosName { get; set; } = null!;

    public int CmpId { get; set; }

    public virtual ICollection<QrCodeMaster> QrCodeMasters { get; set; } = new List<QrCodeMaster>();
}
