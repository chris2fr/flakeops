import os
from ldap3 import Server, Connection, ALL, MODIFY_ADD, MODIFY_REPLACE
from dotenv import load_dotenv

# Load .env
load_dotenv()

LDAP_SERVER = "ldap://ldap.lesgrandsvoisins.com:14389"
BIND_DN = "cn=admin,dc=lesgrandsvoisins,dc=com"
BASE_DN = "ou=users,dc=lesgrandsvoisins,dc=com"

PASSWORD = os.getenv("LDAP_ADMIN_PASSWORD")

if not PASSWORD:
    raise ValueError("LDAP_ADMIN_PASSWORD not found in .env")

def main():
    server = Server(LDAP_SERVER, get_info=ALL)
    conn = Connection(server, user=BIND_DN, password=PASSWORD, auto_bind=True)

    print("Connected to LDAP")

    conn.search(
        search_base=BASE_DN,
        search_filter="(cn=*)",
        attributes=["cn", "mail"]
    )

    i=0

    for entry in conn.entries:

        dn = entry.entry_dn

        cn_values = entry.cn.values if "cn" in entry else []
        mail_values = entry.mail.values if "mail" in entry else []

        if not cn_values:
            continue

        cn = cn_values[0]

        # if "@" not in cn:
        #     continue

        # print(f"\nProcessing {dn}")
        # print(f"Original CN: {cn}")


        conn2 = Connection(server, user=BIND_DN, password=PASSWORD, auto_bind=True)

        for mel in mail_values:
            conn2.search(
                search_base=BASE_DN,
                search_filter=f"(mail={mel})",
                attributes=["cn", "mail"]
            )

            if (len(conn2.entries) > 1):
                for entry2 in conn2.entries:
                    print(f"Duplicates for : {entry2.cn} / {mel} ")

            conn.unbind()

        # updates = {}
        # cd_at_gdvoisins = f"{cn}@gdvoisins.com"

        # # Add uid to mail if missing
        # if cd_at_gdvoisins not in mail_values:
        #     print(f"Adding {cd_at_gdvoisins} to mail attribute")
        #     updates["mail"] = [(MODIFY_ADD, [cd_at_gdvoisins])]

        # # Strip domain from cn
        # # stripped_cn = cn.split("@")[0]
        # # print(f"Updating UID to: {stripped_cn}")

        # # updates["cn"] = [(MODIFY_REPLACE, [stripped_cn])]

        # if updates:
        #     success = conn.modify(dn, updates)
        #     if success:
        #         print("Update successful")
        #     else:
        #         print("Update failed:", conn.result)

        # # i = i + 1


    conn.unbind()
    print("\nDone.")

if __name__ == "__main__":
    main()
