using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V9999MacDetail
{
    public int TranId { get; set; }

    public int MacMasterId { get; set; }

    public int CmpId { get; set; }

    public string MacAddress { get; set; } = null!;

    public byte IsActive { get; set; }

    public int EmpId { get; set; }

    public DateTime? CreatedDate { get; set; }

    public int? ModifiedBy { get; set; }

    public DateTime? LastModified { get; set; }

    public string EmpFullName { get; set; } = null!;

    public string PcName { get; set; } = null!;
}
