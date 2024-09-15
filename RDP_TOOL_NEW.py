import tkinter as tk
from tkinter import messagebox, Listbox
import subprocess

# Function to read the server list from a file
def read_server_list(file_path):
    servers = {}
    current_key = ""
    
    try:
        with open(file_path, 'r') as file:
            for line in file:
                line = line.strip()
                if line.startswith("---") and line.endswith("---"):
                    # New key
                    current_key = line.replace("-", "").strip()
                    servers[current_key] = []
                elif current_key:
                    # Add to the current key's list
                    servers[current_key].append(line)
        return servers
    except FileNotFoundError:
        messagebox.showerror("Error", f"File {file_path} not found.")
        return None

# Function to handle server connection
def connect_to_server():
    selected_value = listbox.get(tk.ACTIVE)
    if selected_value:
        rdp_path = "C:\\Windows\\System32\\mstsc.exe"
        rdp_args = f"/v:{selected_value}"
        try:
            subprocess.run([rdp_path, rdp_args], check=True)
        except Exception as e:
            messagebox.showerror("Error", f"Failed to start RDP: {e}")
    else:
        messagebox.showinfo("No Selection", "Please select a server.")

# Update the listbox based on dropdown selection
def update_listbox(event):
    selected_key = dropdown.get()
    listbox.delete(0, tk.END)
    if selected_key in server_dict:
        for item in server_dict[selected_key]:
            listbox.insert(tk.END, item)

# GUI Setup
root = tk.Tk()
root.title("RDP TOOL")
root.geometry("325x325")
root.resizable(False, False)

# Label
label = tk.Label(root, text="Select a key to view its values:")
label.pack(pady=10)

# Dropdown (Combobox)
dropdown = tk.StringVar(root)
dropdown_menu = tk.OptionMenu(root, dropdown, "")
dropdown_menu.config(width=40)
dropdown_menu.pack()

# Listbox to display server list
listbox = Listbox(root, width=50, height=10)
listbox.pack(pady=10)

# Connect button
connect_button = tk.Button(root, text="Connect", command=connect_to_server)
connect_button.pack(pady=10)

# Load server list
file_path = "serverlist.txt"
server_dict = read_server_list(file_path)

# Populate dropdown
if server_dict:
    dropdown.set("Select a key")
    dropdown_menu['menu'].delete(0, 'end')  # Clear existing options
    for key in server_dict.keys():
        dropdown_menu['menu'].add_command(label=key, command=tk._setit(dropdown, key))
    
    # Bind dropdown selection event
    dropdown.trace("w", update_listbox)

# Start GUI loop
root.mainloop()
